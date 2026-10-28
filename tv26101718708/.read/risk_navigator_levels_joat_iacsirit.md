# Risk Navigator Levels [JOAT]

- url: https://www.tradingview.com/script/iaCSIRit-Risk-Navigator-Levels-JOAT/
- type: indicator
- pine_id: PUB;174e30925c264e05b91af27a46480961
- version: 1.0

## Description

Risk Navigator Levels is an open-source Pine Script v6 overlay that turns confirmed trend-engine flips into a clean visual trade planning map. It draws an entry line, stop line, TP1, TP2, TP3, R-multiple labels, and optional risk/reward boxes after a confirmed setup.

The script is not a full trading system. Its purpose is visual planning: once its internal engine confirms a new long or short state, it freezes the entry, stop, and target levels so the user can inspect structure, distance, and status without manually drawing every line.

[image]https://www.tradingview.com/x/uy9ZoGBR/[/image]

[b]Core Concepts[/b]

[b]1. Trend Engine Gate[/b]

The engine compares a fast EMA, slower EMA basis, ATR gate, and VWAP. A long setup requires the fast line above the basis, price above the upper gate, price above VWAP, and fast-line slope agreement. Shorts use the mirrored logic.

[pine]
riseReady = fastLine > baseLine and close > upperGate and close > vwapLine and fastLine > nz(fastLine[1], fastLine)
fallReady = fastLine < baseLine and close < lowerGate and close < vwapLine and fastLine < nz(fastLine[1], fastLine)
[/pine]

[b]2. Confirmed Direction Change[/b]

The script only creates a new level set when the engine direction changes on a confirmed bar.

[pine]
confirmedLong = barstate.isconfirmed and engineDir == 1 and previousDir != 1
confirmedShort = barstate.isconfirmed and engineDir == -1 and previousDir != -1
[/pine]

[b]3. Stop Selection[/b]

The stop is based on recent swing lookback and an ATR floor. This prevents the stop from being unrealistically tight relative to current volatility.

[b]4. R-Multiple Targets[/b]

Once risk is calculated, TP1, TP2, and TP3 are plotted as multiples of that risk. The default values are 1R, 2R, and 3R.

[b]5. Status Tracking[/b]

After a setup, the script tracks whether the stop or each target has been touched on confirmed bars and updates labels and dashboard status.

[b]Features[/b]

[list]
[*][b]Confirmed setup engine:[/b] Uses EMA, ATR gate, VWAP, and slope checks
[*][b]Frozen entry and stop:[/b] Levels are created at setup time
[*][b]TP1, TP2, TP3 targets:[/b] Target levels are R-multiple based
[*][b]Risk/reward boxes:[/b] Optional green and red boxes show distance visually
[*][b]Status labels:[/b] Shows whether SL, TP1, TP2, or TP3 has been touched
[*][b]Right-edge labels:[/b] Keeps levels readable without crowding older bars
[*][b]Dashboard:[/b] Shows mode, engine state, R size, targets, and status
[*][b]Alerts:[/b] Setup, stop touch, and target touch conditions
[/list]

[b]Input Parameters[/b]

[b]Visuals:[/b]
[list]
[*]Palette Preset: Selects color pair
[*]Level Reach Bars: Forward extension of lines and boxes
[*]Risk/Reward Boxes: Toggles the boxes
[/list]

[b]Engine:[/b]
[list]
[*]Source: Price source
[*]Fast Length: Fast EMA length
[*]Base Length: Slow EMA basis length
[*]ATR Length: Volatility length
[*]Confirmation Gate: ATR gate around the basis
[/list]

[b]Risk:[/b]
[list]
[*]Stop Lookback: Swing lookback used for stop reference
[*]ATR Stop Floor: Minimum stop distance multiplier
[*]TP1 R / TP2 R / TP3 R: Target multiples
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Wait for a Confirmed Setup[/b]
The script draws a new plan only after its engine direction changes on a confirmed bar.

[b]Step 2: Inspect R Size[/b]
The dashboard R size shows the distance between entry and stop. Large R size means the setup requires wider risk.

[b]Step 3: Monitor Touch Status[/b]
Labels and dashboard status update when the stop or targets are touched after the setup bar.

[b]Step 4: Use as a Planning Tool[/b]
The levels help visualize trade structure. They do not replace account-level risk controls.

[b]Indicator Limitations[/b]

[list]
[*]This is a visual planning tool, not a complete execution strategy
[*]The engine can produce late signals during fast reversals
[*]Targets are mathematical R levels, not forecasts
[*]A stop touch and target touch can occur in the same bar on some candles; intrabar order cannot be known from closed OHLC alone
[/list]

[b]Originality Statement[/b]

Risk Navigator Levels is original in its integration of a confirmed trend gate, VWAP location, ATR stop floor, frozen R-level drawing system, and live status tracking. It is built as original Pine v6 code for transparent visual planning.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Levels shown by the script are visual research levels and may not match actual execution conditions. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Risk Navigator Levels [JOAT]", overlay = true, max_lines_count = 80, max_labels_count = 80, max_boxes_count = 20)

f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

f_bullColor(string preset) =>
    switch preset
        "Neon Desk" => #00ff00
        "Mint Pulse" => #00FFD5
        "VWAP Field" => #1ac200
        => #00C8FF

f_bearColor(string preset) =>
    switch preset
        "Neon Desk" => #ff0000
        "Mint Pulse" => #FF0066
        "VWAP Field" => #ff4040
        => #FF005D

paletteInput = input.string("Aqua Rose", "Palette preset", options = ["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"], group = "Visuals")
rightBarsInput = input.int(40, "Level reach bars", minval = 10, maxval = 200, group = "Visuals")
showBoxesInput = input.bool(true, "Risk/reward boxes", group = "Visuals")

sourceInput = input.source(hlc3, "Source", group = "Engine")
fastLenInput = input.int(12, "Fast length", minval = 2, group = "Engine")
slowLenInput = input.int(34, "Base length", minval = 5, group = "Engine")
atrLenInput = input.int(14, "ATR length", minval = 1, group = "Engine")
gateMultInput = input.float(0.55, "Confirmation gate", minval = 0.1, step = 0.05, group = "Engine")
swingLenInput = input.int(12, "Stop lookback", minval = 2, group = "Risk")
stopMultInput = input.float(1.35, "ATR stop floor", minval = 0.2, step = 0.05, group = "Risk")
tp1Input = input.float(1.0, "TP1 R", minval = 0.25, step = 0.25, group = "Risk")
tp2Input = input.float(2.0, "TP2 R", minval = 0.5, step = 0.25, group = "Risk")
tp3Input = input.float(3.0, "TP3 R", minval = 0.75, step = 0.25, group = "Risk")

bullBase = f_bullColor(paletteInput)
bearBase = f_bearColor(paletteInput)
neutralColor = color.rgb(210, 215, 225)

atrSeed = math.max(high - low, syminfo.mintick)
atrValue = math.max(nz(ta.atr(atrLenInput), atrSeed), syminfo.mintick)
vwapRaw = ta.vwap(sourceInput)
vwapLine = nz(vwapRaw, ta.ema(sourceInput, slowLenInput))
fastLine = ta.ema(sourceInput, fastLenInput)
baseLine = ta.ema(sourceInput, slowLenInput)
gateLift = atrValue * gateMultInput
upperGate = baseLine + gateLift
lowerGate = baseLine - gateLift
riseReady = fastLine > baseLine and close > upperGate and close > vwapLine and fastLine > nz(fastLine[1], fastLine)
fallReady = fastLine < baseLine and close < lowerGate and close < vwapLine and fastLine < nz(fastLine[1], fastLine)

var int engineDir = 0
previousDir = nz(engineDir[1], 0)
engineDir := previousDir

if barstate.isconfirmed
    if riseReady
        engineDir := 1
    else if fallReady
        engineDir := -1

confirmedLong = barstate.isconfirmed and engineDir == 1 and previousDir != 1
confirmedShort = barstate.isconfirmed and engineDir == -1 and previousDir != -1

entryCandidate = close
longStopCandidate = math.min(ta.lowest(low, swingLenInput), entryCandidate - atrValue * stopMultInput)
shortStopCandidate = math.max(ta.highest(high, swingLenInput), entryCandidate + atrValue * stopMultInput)

var int activeDir = 0
var float activeEntry = na
var float activeStop = na
var float activeTp1 = na
var float activeTp2 = na
var float activeTp3 = na
var float activeRisk = na
var int activeStartBar = na
var bool stopDone = false
var bool tp1Done = false
var bool tp2Done = false
var bool tp3Done = false
var string activeStatus = "Waiting"

var box riskBox = na
var box rewardBox = na
var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label entryLabel = na
var label stopLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var label statusLabel = na

newSetup = confirmedLong or confirmedShort

if newSetup
    if not na(riskBox)
        box.delete(riskBox)
    if not na(rewardBox)
        box.delete(rewardBox)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(stopLabel)
        label.delete(stopLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)
    if not na(statusLabel)
        label.delete(statusLabel)

    activeDir := confirmedLong ? 1 : -1
    activeEntry := entryCandidate
    activeStop := confirmedLong ? longStopCandidate : shortStopCandidate
    rawRisk = math.max(math.abs(activeEntry - activeStop), syminfo.mintick * 10.0)
    activeRisk := rawRisk
    activeStop := activeDir == 1 ? activeEntry - activeRisk : activeEntry + activeRisk
    activeTp1 := activeDir == 1 ? activeEntry + activeRisk * tp1Input : activeEntry - activeRisk * tp1Input
    activeTp2 := activeDir == 1 ? activeEntry + activeRisk * tp2Input : activeEntry - activeRisk * tp2Input
    activeTp3 := activeDir == 1 ? activeEntry + activeRisk * tp3Input : activeEntry - activeRisk * tp3Input
    activeStartBar := bar_index
    stopDone := false
    tp1Done := false
    tp2Done := false
    tp3Done := false
    activeStatus := activeDir == 1 ? "Long live" : "Short live"

    rightEdge = bar_index + rightBarsInput
    rewardTop = activeDir == 1 ? activeTp3 : activeEntry
    rewardBottom = activeDir == 1 ? activeEntry : activeTp3
    riskTop = activeDir == 1 ? activeEntry : activeStop
    riskBottom = activeDir == 1 ? activeStop : activeEntry
    riskTint = color.new(bearBase, 88)
    rewardTint = color.new(bullBase, 88)
    edgeTint = color.new(neutralColor, 54)

    if showBoxesInput
        riskBox := box.new(left = bar_index, top = riskTop, right = rightEdge, bottom = riskBottom, xloc = xloc.bar_index, border_color = color.new(bearBase, 42), bgcolor = riskTint)
        rewardBox := box.new(left = bar_index, top = rewardTop, right = rightEdge, bottom = rewardBottom, xloc = xloc.bar_index, border_color = color.new(bullBase, 42), bgcolor = rewardTint)
    else
        riskBox := na
        rewardBox := na

    entryLine := line.new(bar_index, activeEntry, rightEdge, activeEntry, xloc = xloc.bar_index, color = edgeTint, width = 2)
    stopLine := line.new(bar_index, activeStop, rightEdge, activeStop, xloc = xloc.bar_index, color = color.new(bearBase, 0), width = 2, style = line.style_dashed)
    tp1Line := line.new(bar_index, activeTp1, rightEdge, activeTp1, xloc = xloc.bar_index, color = color.new(bullBase, 36), width = 1)
    tp2Line := line.new(bar_index, activeTp2, rightEdge, activeTp2, xloc = xloc.bar_index, color = color.new(bullBase, 22), width = 1)
    tp3Line := line.new(bar_index, activeTp3, rightEdge, activeTp3, xloc = xloc.bar_index, color = color.new(bullBase, 8), width = 2)
    entryLabel := label.new(rightEdge, activeEntry, "Entry", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 8), textcolor = color.white, size = size.small)
    stopLabel := label.new(rightEdge, activeStop, "SL -1R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bearBase, 8), textcolor = color.white, size = size.small)
    tp1Label := label.new(rightEdge, activeTp1, "TP1 " + str.tostring(tp1Input, "#.##") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullBase, 18), textcolor = color.white, size = size.small)
    tp2Label := label.new(rightEdge, activeTp2, "TP2 " + str.tostring(tp2Input, "#.##") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullBase, 12), textcolor = color.white, size = size.small)
    tp3Label := label.new(rightEdge, activeTp3, "TP3 " + str.tostring(tp3Input, "#.##") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullBase, 6), textcolor = color.white, size = size.small)
    statusLabel := label.new(bar_index, activeEntry, activeStatus, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(activeDir == 1 ? bullBase : bearBase, 10), textcolor = color.white, size = size.small)

stopNow = false
tp1Now = false
tp2Now = false
tp3Now = false

if barstate.isconfirmed and activeDir != 0 and bar_index > nz(activeStartBar, bar_index)
    stopTouch = activeDir == 1 ? low <= activeStop : high >= activeStop
    tp1Touch = activeDir == 1 ? high >= activeTp1 : low <= activeTp1
    tp2Touch = activeDir == 1 ? high >= activeTp2 : low <= activeTp2
    tp3Touch = activeDir == 1 ? high >= activeTp3 : low <= activeTp3
    stopNow := stopTouch and not stopDone
    tp1Now := tp1Touch and not tp1Done
    tp2Now := tp2Touch and not tp2Done
    tp3Now := tp3Touch and not tp3Done
    if stopNow
        stopDone := true
        activeStatus := "SL touched"
    if tp1Now
        tp1Done := true
        activeStatus := "TP1 touched"
    if tp2Now
        tp2Done := true
        activeStatus := "TP2 touched"
    if tp3Now
        tp3Done := true
        activeStatus := "TP3 touched"

if activeDir != 0 and not na(entryLine)
    rightEdge = bar_index + rightBarsInput
    line.set_x2(entryLine, rightEdge)
    line.set_x2(stopLine, rightEdge)
    line.set_x2(tp1Line, rightEdge)
    line.set_x2(tp2Line, rightEdge)
    line.set_x2(tp3Line, rightEdge)
    line.set_color(stopLine, stopDone ? color.new(bearBase, 0) : color.new(bearBase, 18))
    line.set_color(tp1Line, tp1Done ? color.new(bullBase, 0) : color.new(bullBase, 36))
    line.set_color(tp2Line, tp2Done ? color.new(bullBase, 0) : color.new(bullBase, 22))
    line.set_color(tp3Line, tp3Done ? color.new(bullBase, 0) : color.new(bullBase, 8))
    if not na(riskBox)
        box.set_right(riskBox, rightEdge)
    if not na(rewardBox)
        box.set_right(rewardBox, rightEdge)
    label.set_x(entryLabel, rightEdge)
    label.set_x(stopLabel, rightEdge)
    label.set_x(tp1Label, rightEdge)
    label.set_x(tp2Label, rightEdge)
    label.set_x(tp3Label, rightEdge)
    label.set_x(statusLabel, bar_index)
    label.set_text(statusLabel, activeStatus)
    label.set_color(statusLabel, color.new(activeStatus == "SL touched" ? bearBase : activeDir == 1 ? bullBase : bearBase, 10))

var table dash = table.new(position.top_right, 2, 5, border_color = color.new(neutralColor, 78), border_width = 1)

if barstate.islast
    modeText = activeDir == 1 ? "Long" : activeDir == -1 ? "Short" : "Waiting"
    modeColor = activeDir == 1 ? bullBase : activeDir == -1 ? bearBase : neutralColor
    riskText = activeDir == 0 or na(activeRisk) ? "None" : str.tostring(activeRisk, format.mintick)
    rrText = str.tostring(tp1Input, "#.##") + "/" + str.tostring(tp2Input, "#.##") + "/" + str.tostring(tp3Input, "#.##")
    gateText = engineDir == 1 ? "Bull" : engineDir == -1 ? "Bear" : "Flat"
    table.cell(dash, 0, 0, "Risk Nav", text_color = color.white, bgcolor = color.new(modeColor, 15), text_size = size.small)
    table.cell(dash, 1, 0, modeText, text_color = color.white, bgcolor = color.new(modeColor, 15), text_size = size.small)
    table.cell(dash, 0, 1, "Engine", text_color = neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 1, 1, gateText, text_color = modeColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 0, 2, "R size", text_color = neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 1, 2, riskText, text_color = color.from_gradient(activeDir == 0 or na(activeRisk) ? 0.0 : activeRisk / atrValue, 0.0, 3.0, neutralColor, modeColor), bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 0, 3, "Targets", text_color = neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 1, 3, rrText, text_color = bullBase, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 0, 4, "Status", text_color = neutralColor, bgcolor = color.new(color.black, 72), text_size = size.small)
    table.cell(dash, 1, 4, activeStatus, text_color = activeStatus == "SL touched" ? bearBase : modeColor, bgcolor = color.new(color.black, 72), text_size = size.small)

alertcondition(confirmedLong, "Risk Navigator Long Setup [JOAT]", "Risk Navigator Levels [JOAT]: confirmed long setup")
alertcondition(confirmedShort, "Risk Navigator Short Setup [JOAT]", "Risk Navigator Levels [JOAT]: confirmed short setup")
alertcondition(stopNow, "Risk Navigator SL Touched [JOAT]", "Risk Navigator Levels [JOAT]: stop level touched on a confirmed bar")
alertcondition(tp1Now, "Risk Navigator TP1 Touched [JOAT]", "Risk Navigator Levels [JOAT]: TP1 touched on a confirmed bar")
alertcondition(tp2Now, "Risk Navigator TP2 Touched [JOAT]", "Risk Navigator Levels [JOAT]: TP2 touched on a confirmed bar")
alertcondition(tp3Now, "Risk Navigator TP3 Touched [JOAT]", "Risk Navigator Levels [JOAT]: TP3 touched on a confirmed bar")
````
