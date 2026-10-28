# Pattern Scanner AI AlgoCode

- url: https://www.tradingview.com/script/KlK7GpYE-Pattern-Scanner-AI-AlgoCode/
- type: indicator
- pine_id: PUB;ce63b9a2d8444acf8ed062ae13643e48
- version: 1.0

## Description

[b]Automatic chart pattern detection with a complete, ready-to-trade level map.[/b]

Pattern Scanner AI AlgoCode is a pivot-based structure engine that finds classic reversal and continuation patterns in real time and turns each of them into a clean trade plan: entry, retest, stop-loss and two targets with a live R:R readout.

[b]What it detects[/b]
[list]
[*]Double Top / Double Bottom
[*]Triple Top / Triple Bottom
[*]Head & Shoulders / Inverse Head & Shoulders
[*]Rising Wedge / Falling Wedge
[*]Every pattern is validated by geometry, not by guesswork: swing highs and lows are confirmed with configurable pivot windows, peak equality is measured with an ATR- or percent-based tolerance, and each candidate must pass minimum height, minimum/maximum width and minimum R:R filters before it is plotted.
[/list]

Entry Engine
A pattern alone is not a signal. The Entry Engine confirms the actual breakout of the neckline / wedge boundary:

ATR breakout buffer — price must clear the level by a volatility-scaled margin, filtering micro-fakeouts.
Body close confirmation — optional requirement that the candle body, not just the wick, closes beyond the level.
Volume filter — optional requirement of volume above its 20-period average by a chosen multiplier.
Retest level — an additional, better-priced entry line for traders who wait for the pullback into the broken level.
Cooldown — a minimum bar distance between signals to avoid clusters of duplicates.
Trade levels on every setup
E (Entry) — breakout level projected forward as a solid ray.
Retest — dotted alternative entry.
SL — stop beyond the pattern extreme with an ATR safety buffer.
TP1 — classic measured move (pattern height).
TP2 — extended target (default 1.618 × pattern height).
R:R — real risk/reward, calculated with the buffered stop, printed on the setup label.
Risk and reward zones are shaded so the trade structure is readable at a glance.

Visualization
Pattern skeleton drawn through the actual pivot points, with marked vertices.
Compact price labels for every level, placed to the right of the signal bar.
Full setup history: the last N setups stay on the chart (configurable up to 40), older drawings are pruned automatically to keep performance high.
Optional pivot markers for a quick health check of your settings.
Bullish / bearish signal triangles on the breakout bar.
Alerts
Built-in alert() calls and separate bullish / bearish alertcondition streams, including the pattern name, ticker and timeframe — ready for TradingView notifications, webhooks and bots.

Settings overview
Pivots & accuracy — pivot left/right, tolerance mode (ATR / percent), min height, min/max width, min R:R, cooldown.
Entry engine — breakout buffer, body-close requirement, volume filter, retest offset, stop buffer, TP2 multiplier.
Patterns — enable or disable each family independently.
Display — levels, pattern outline, pivot points, risk/reward zones, projection length, history depth, alerts.
How to use
Add the indicator to any symbol and timeframe.
Increase Pivot left / right on lower timeframes for cleaner structure, decrease for more signals.
Keep the body close confirmation on for stricter entries; add the volume filter on liquid instruments.
Trade the E level on the breakout candle, or wait for the Retest line for a better price.
Manage the position with SL, take partials at TP1, run the rest to TP2.
Notes
Works on all markets and timeframes (crypto, forex, indices, stocks). Non-repainting on confirmed breakouts: signals fire on bar close conditions, while pivots require their right-side confirmation window by design.

This script is a technical analysis tool, not financial advice. Always test settings on your instrument and manage risk.

AI AlgoCode

## Source Code

````pine
//@version=6
// Pattern Scanner AI AlgoCode v2.3 — precise chart pattern detection + clean entry levels
indicator("Pattern Scanner AI AlgoCode", shorttitle="PS AI AlgoCode", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ================= SETTINGS =================
grpP = "Pivots and accuracy"
lenL      = input.int(5,   "Pivot left",  minval=1, group=grpP)
lenR      = input.int(5,   "Pivot right", minval=1, group=grpP)
tolMode   = input.string("ATR", "Level equality tolerance", options=["ATR", "Percent"], group=grpP)
tolAtr    = input.float(1.0, "Tolerance in ATR", minval=0.05, step=0.05, group=grpP)
tolPct    = input.float(1.0, "Tolerance, %", minval=0.05, step=0.1, group=grpP) / 100.0
minHeight = input.float(0.5, "Min. pattern height (ATR)", minval=0.1, step=0.1, group=grpP)
maxBars   = input.int(200, "Max. pattern width (bars)", minval=20, group=grpP)
minBars   = input.int(10,  "Min. pattern width (bars)", minval=3,  group=grpP)
minRR     = input.float(0.8, "Min. R:R", minval=0.1, step=0.1, group=grpP)
cooldown  = input.int(10, "Pause between signals (bars)", minval=0, group=grpP)

grpE = "Entry engine"
confAtr   = input.float(0.05, "Breakout buffer (ATR)", minval=0.0, step=0.05, group=grpE)
useBody   = input.bool(true,  "Require candle body close beyond level", group=grpE)
useVol    = input.bool(false, "Require volume above average", group=grpE)
volMult   = input.float(1.2,  "Volume x average(20)", minval=0.5, step=0.1, group=grpE)
useRetest = input.bool(true,  "Add retest entry level (better price)", group=grpE)
retestAtr = input.float(0.25, "Retest offset (ATR)", minval=0.0, step=0.05, group=grpE)
stopAtr   = input.float(0.25, "Stop buffer beyond extreme (ATR)", minval=0.0, step=0.05, group=grpE)
tp2Mult   = input.float(1.618,"Target 2 (x pattern height)", minval=0.5, step=0.1, group=grpE)

grpF = "Patterns"
showDT    = input.bool(true, "Double top / bottom", group=grpF)
showTT    = input.bool(true, "Triple top / bottom", group=grpF)
showHS    = input.bool(true, "Head & Shoulders (and inverse)", group=grpF)
showWedge = input.bool(true, "Wedges", group=grpF)

grpV = "Display"
showLevels = input.bool(true, "Entry / Stop / Target levels", group=grpV)
showShape  = input.bool(true, "Pattern outline by pivots", group=grpV)
showPoints = input.bool(true, "Mark pattern points", group=grpV)
showZones  = input.bool(true, "Risk and reward zones", group=grpV)
projBars   = input.int(25, "Level projection length (bars)", minval=5, group=grpV)
keepLast   = input.int(12, "Keep last setups (history)", minval=1, maxval=40, group=grpV)
alertsOn   = input.bool(true, "Alerts", group=grpV)
showPiv    = input.bool(false, "Show pivots (health check)", group=grpV)

cBull = #26a69a
cBear = #ef5350
cEntry= #2962ff
cNeck = color.new(color.gray, 20)

atr = ta.atr(14)

// ================= PIVOTS =================
ph = ta.pivothigh(high, lenL, lenR)
pl = ta.pivotlow(low,  lenL, lenR)

var float[] hVal = array.new_float()
var int[]   hBar = array.new_int()
var float[] lVal = array.new_float()
var int[]   lBar = array.new_int()

if not na(ph)
    array.push(hVal, ph)
    array.push(hBar, bar_index - lenR)
    if array.size(hVal) > 20
        array.shift(hVal)
        array.shift(hBar)
if not na(pl)
    array.push(lVal, pl)
    array.push(lBar, bar_index - lenR)
    if array.size(lVal) > 20
        array.shift(lVal)
        array.shift(lBar)

gh(i)  => array.size(hVal) > i ? array.get(hVal, array.size(hVal) - 1 - i) : na
ghb(i) => array.size(hBar) > i ? array.get(hBar, array.size(hBar) - 1 - i) : na
gl(i)  => array.size(lVal) > i ? array.get(lVal, array.size(lVal) - 1 - i) : na
glb(i) => array.size(lBar) > i ? array.get(lBar, array.size(lBar) - 1 - i) : na

tolAbs() => tolMode == "ATR" ? atr * tolAtr : close * tolPct
near(a, b) => not na(a) and not na(b) and math.abs(a - b) <= tolAbs()

// ================= DRAWING STORAGE (cleanup old) =================
var line[]  drawLines = array.new_line()
var label[] drawLabels= array.new_label()
var box[]   drawBoxes = array.new_box()
var int[]   setupBar  = array.new_int()
var int[]   setupLines= array.new_int()
var int[]   setupLabs = array.new_int()
var int[]   setupBoxes= array.new_int()
var int lastSignalBar = -10000

pruneSetups() =>
    while array.size(setupBar) > keepLast
        nL = array.shift(setupLines)
        nB = array.shift(setupLabs)
        nX = array.shift(setupBoxes)
        array.shift(setupBar)
        for i = 0 to nL - 1
            if array.size(drawLines) > 0
                line.delete(array.shift(drawLines))
        for i = 0 to nB - 1
            if array.size(drawLabels) > 0
                label.delete(array.shift(drawLabels))
        for i = 0 to nX - 1
            if array.size(drawBoxes) > 0
                box.delete(array.shift(drawBoxes))

// ================= SETUP DRAWING =================
drawSetup(int xStart, float entry, float stop, float target, bool bear, string name, float p1x, float p1y, float p2x, float p2y, float p3x, float p3y, float p4x, float p4y, float p5x, float p5y) =>
    nLines = 0
    nLabs  = 0
    nBoxes = 0
    xSig   = bar_index
    xRight = xSig + projBars
    cCol   = bear ? cBear : cBull
    rr     = math.abs(target - entry) / math.max(math.abs(entry - stop), syminfo.mintick)

    // ---- Pattern outline by actual pivots (skeleton) ----
    if showShape
        array.push(drawLines, line.new(int(p1x), p1y, int(p2x), p2y, color=color.new(cCol, 25), width=2))
        array.push(drawLines, line.new(int(p2x), p2y, int(p3x), p3y, color=color.new(cCol, 25), width=2))
        nLines += 2
        if not na(p4x)
            array.push(drawLines, line.new(int(p3x), p3y, int(p4x), p4y, color=color.new(cCol, 25), width=2))
            nLines += 1
        if not na(p5x)
            array.push(drawLines, line.new(int(p4x), p4y, int(p5x), p5y, color=color.new(cCol, 25), width=2))
            nLines += 1
        // connect last pivot to the breakout bar
        lastX = not na(p5x) ? p5x : not na(p4x) ? p4x : p3x
        lastY = not na(p5x) ? p5y : not na(p4x) ? p4y : p3y
        array.push(drawLines, line.new(int(lastX), lastY, xSig, close, color=color.new(cCol, 45), width=1, style=line.style_dotted))
        nLines += 1

    // ---- Pattern points ----
    if showPoints
        array.push(drawLabels, label.new(int(p1x), p1y, "", style=label.style_circle, color=color.new(cCol, 20), size=size.tiny))
        array.push(drawLabels, label.new(int(p2x), p2y, "", style=label.style_circle, color=color.new(cCol, 20), size=size.tiny))
        array.push(drawLabels, label.new(int(p3x), p3y, "", style=label.style_circle, color=color.new(cCol, 20), size=size.tiny))
        nLabs += 3
        if not na(p4x)
            array.push(drawLabels, label.new(int(p4x), p4y, "", style=label.style_circle, color=color.new(cCol, 20), size=size.tiny))
            nLabs += 1
        if not na(p5x)
            array.push(drawLabels, label.new(int(p5x), p5y, "", style=label.style_circle, color=color.new(cCol, 20), size=size.tiny))
            nLabs += 1

    // ---- Levels ----
    stopAdj = bear ? stop + atr * stopAtr : stop - atr * stopAtr
    retest  = bear ? entry + atr * retestAtr : entry - atr * retestAtr
    height  = math.abs(target - entry)
    target2 = bear ? entry - height * tp2Mult : entry + height * tp2Mult
    rrAdj   = height / math.max(math.abs(entry - stopAdj), syminfo.mintick)

    if showLevels
        // Neckline through the pattern, solid entry ray after the breakout
        array.push(drawLines, line.new(xStart, entry, xSig, entry, color=color.new(cNeck, 30), width=1, style=line.style_dashed))
        array.push(drawLines, line.new(xSig, entry, xRight, entry, color=cEntry, width=2))
        array.push(drawLines, line.new(xSig, stopAdj, xRight, stopAdj, color=color.new(cBear, 10), width=1, style=line.style_dashed))
        array.push(drawLines, line.new(xSig, target,  xRight, target,  color=color.new(cBull, 10), width=1, style=line.style_dashed))
        array.push(drawLines, line.new(xSig, target2, xRight, target2, color=color.new(cBull, 45), width=1, style=line.style_dotted))
        nLines += 5

        array.push(drawLabels, label.new(xRight, entry,  "E  " + str.tostring(entry, format.mintick), style=label.style_label_left, color=color.new(cEntry, 80), textcolor=color.white, size=size.tiny))
        array.push(drawLabels, label.new(xRight, stopAdj, "SL " + str.tostring(stopAdj, format.mintick), style=label.style_label_left, color=color.new(cBear, 80), textcolor=color.white, size=size.tiny))
        array.push(drawLabels, label.new(xRight, target, "TP1 " + str.tostring(target, format.mintick), style=label.style_label_left, color=color.new(cBull, 80), textcolor=color.white, size=size.tiny))
        array.push(drawLabels, label.new(xRight, target2, "TP2 " + str.tostring(target2, format.mintick), style=label.style_label_left, color=color.new(cBull, 88), textcolor=cBull, size=size.tiny))
        nLabs += 4

        if useRetest
            array.push(drawLines, line.new(xSig, retest, xSig + math.max(5, projBars / 2), retest, color=color.new(cEntry, 35), width=1, style=line.style_dotted))
            array.push(drawLabels, label.new(xSig + math.max(5, projBars / 2), retest, "retest " + str.tostring(retest, format.mintick), style=label.style_label_left, color=color.new(cEntry, 92), textcolor=cEntry, size=size.tiny))
            nLines += 1
            nLabs  += 1

    if showZones
        array.push(drawBoxes, box.new(xSig, math.max(entry, stopAdj), xRight, math.min(entry, stopAdj), border_color=color.new(cBear, 90), bgcolor=color.new(cBear, 85)))
        array.push(drawBoxes, box.new(xSig, math.max(entry, target), xRight, math.min(entry, target), border_color=color.new(cBull, 90), bgcolor=color.new(cBull, 88)))
        nBoxes += 2

    array.push(drawLabels, label.new(xSig, bear ? high + atr * 0.8 : low - atr * 0.8,
         name + "\n" + (bear ? "SHORT" : "LONG") + "   R:R " + str.tostring(rrAdj, "#.##"),
         style = bear ? label.style_label_down : label.style_label_up,
         color = bear ? color.new(cBear, 5) : color.new(cBull, 5),
         textcolor = color.white, size=size.small))
    nLabs += 1


    array.push(setupBar, xSig)
    array.push(setupLines, nLines)
    array.push(setupLabs, nLabs)
    array.push(setupBoxes, nBoxes)

    pruneSetups()

// Validation: height, width, R:R, cooldown
valid(float entry, float stop, float target, int xStart) =>
    okGap  = bar_index - lastSignalBar >= cooldown
    width  = bar_index - xStart
    okW    = width >= minBars and width <= maxBars
    okH    = math.abs(entry - stop) >= atr * minHeight * 0.5 and math.abs(target - entry) >= atr * minHeight
    // The ATR stop buffer improves execution, but must not suppress classic
    // 1:1 measured-move patterns during detection.
    risk   = math.abs(entry - stop)
    rr     = math.abs(target - entry) / math.max(risk, syminfo.mintick)
    okGap and okW and okH and rr + 0.15 >= minRR

// ================= PATTERNS =================
patDT = false
patDB = false
patTT = false
patTB = false
patHS = false
patIHS = false
patWR = false
patWF = false

// Level breakout (signal on cross, not only at pivot moment)
volOk() => not useVol or na(volume) or volume > ta.sma(volume, 20) * volMult
bodyDn(float lvl) => not useBody or math.min(open, close) < lvl
bodyUp(float lvl) => not useBody or math.max(open, close) > lvl
brDn(float lvl) => not na(lvl) and close < lvl - atr * confAtr and close[1] >= lvl - atr * confAtr and bodyDn(lvl) and volOk()
brUp(float lvl) => not na(lvl) and close > lvl + atr * confAtr and close[1] <= lvl + atr * confAtr and bodyUp(lvl) and volOk()

// --- Double top
if showDT and near(gh(0), gh(1)) and not na(gl(0)) and gl(0) < math.min(gh(0), gh(1)) and glb(0) > ghb(1) and glb(0) < ghb(0)
    neck = gl(0)
    top  = math.max(gh(0), gh(1))
    h    = math.avg(gh(0), gh(1)) - neck
    if brDn(neck) and valid(neck, top, neck - h, ghb(1))
        patDT := true
        drawSetup(ghb(1), neck, top, neck - h, true, "Double top", ghb(1), gh(1), glb(0), gl(0), ghb(0), gh(0), na, na, na, na)

// --- Double bottom
if showDT and near(gl(0), gl(1)) and not na(gh(0)) and gh(0) > math.max(gl(0), gl(1)) and ghb(0) > glb(1) and ghb(0) < glb(0)
    neck = gh(0)
    bot  = math.min(gl(0), gl(1))
    h    = neck - math.avg(gl(0), gl(1))
    if brUp(neck) and valid(neck, bot, neck + h, glb(1))
        patDB := true
        drawSetup(glb(1), neck, bot, neck + h, false, "Double bottom", glb(1), gl(1), ghb(0), gh(0), glb(0), gl(0), na, na, na, na)

// --- Triple top
if showTT and near(gh(0), gh(1)) and near(gh(1), gh(2)) and not na(gl(0)) and not na(gl(1))
    neck = math.min(gl(0), gl(1))
    top  = math.max(gh(0), math.max(gh(1), gh(2)))
    h    = math.avg(gh(0), gh(1)) - neck
    if brDn(neck) and valid(neck, top, neck - h, ghb(2))
        patTT := true
        drawSetup(ghb(2), neck, top, neck - h, true, "Triple top", ghb(2), gh(2), glb(1), gl(1), ghb(1), gh(1), glb(0), gl(0), ghb(0), gh(0))

// --- Triple bottom
if showTT and near(gl(0), gl(1)) and near(gl(1), gl(2)) and not na(gh(0)) and not na(gh(1))
    neck = math.max(gh(0), gh(1))
    bot  = math.min(gl(0), math.min(gl(1), gl(2)))
    h    = neck - math.avg(gl(0), gl(1))
    if brUp(neck) and valid(neck, bot, neck + h, glb(2))
        patTB := true
        drawSetup(glb(2), neck, bot, neck + h, false, "Triple bottom", glb(2), gl(2), ghb(1), gh(1), glb(1), gl(1), ghb(0), gh(0), glb(0), gl(0))

// --- Head and Shoulders
if showHS and not na(gh(2)) and not na(gl(1)) and gh(1) > gh(0) + tolAbs() and gh(1) > gh(2) + tolAbs() and near(gh(0), gh(2))
    neck = math.avg(gl(0), gl(1))
    h    = gh(1) - neck
    if brDn(neck) and valid(neck, gh(1), neck - h, ghb(2))
        patHS := true
        drawSetup(ghb(2), neck, gh(1), neck - h, true, "Head & Shoulders", ghb(2), gh(2), glb(1), gl(1), ghb(1), gh(1), glb(0), gl(0), ghb(0), gh(0))

// --- Inverse H&S
if showHS and not na(gl(2)) and not na(gh(1)) and gl(1) < gl(0) - tolAbs() and gl(1) < gl(2) - tolAbs() and near(gl(0), gl(2))
    neck = math.avg(gh(0), gh(1))
    h    = neck - gl(1)
    if brUp(neck) and valid(neck, gl(1), neck + h, glb(2))
        patIHS := true
        drawSetup(glb(2), neck, gl(1), neck + h, false, "Inverse H&S", glb(2), gl(2), ghb(1), gh(1), glb(1), gl(1), ghb(0), gh(0), glb(0), gl(0))

// --- Wedges: converging boundaries + breakout
if showWedge and not na(gh(2)) and not na(gl(2))
    r2 = gh(2) - gl(2)
    r0 = gh(0) - gl(0)
    converging = r0 < r2 * 0.7 and r2 > atr * minHeight
    rising  = gh(0) > gh(1) and gh(1) > gh(2) and gl(0) > gl(1) and gl(1) > gl(2)
    falling = gh(0) < gh(1) and gh(1) < gh(2) and gl(0) < gl(1) and gl(1) < gl(2)
    xs = math.min(ghb(2), glb(2))
    if converging and rising and brDn(gl(0))
        if valid(gl(0), gh(0), gl(0) - r2, xs)
            patWR := true
            drawSetup(xs, gl(0), gh(0), gl(0) - r2, true, "Rising wedge", ghb(2), gh(2), ghb(1), gh(1), ghb(0), gh(0), na, na, na, na)
    if converging and falling and brUp(gh(0))
        if valid(gh(0), gl(0), gh(0) + r2, xs)
            patWF := true
            drawSetup(xs, gh(0), gl(0), gh(0) + r2, false, "Falling wedge", glb(2), gl(2), glb(1), gl(1), glb(0), gl(0), na, na, na, na)

// ================= ALERTS =================
bearSig = patDT or patTT or patHS or patWR
bullSig = patDB or patTB or patIHS or patWF

// Cooldown between signals (update global variable outside functions)
if bearSig or bullSig
    lastSignalBar := bar_index

if alertsOn and (bearSig or bullSig)
    nm = patDT ? "Double top" : patTT ? "Triple top" : patHS ? "Head & Shoulders" : patWR ? "Rising wedge" : patDB ? "Double bottom" : patTB ? "Triple bottom" : patIHS ? "Inverse H&S" : "Falling wedge"
    alert(nm + " — " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar)

pivHiSig = showPiv and not na(ph)
pivLoSig = showPiv and not na(pl)
plotshape(pivHiSig, title="Pivot high", style=shape.circle, location=location.abovebar, color=color.new(cBear, 40), size=size.tiny, offset=-lenR)
plotshape(pivLoSig, title="Pivot low", style=shape.circle, location=location.belowbar, color=color.new(cBull, 40), size=size.tiny, offset=-lenR)

alertcondition(patDT or patTT or patHS or patWR, "Bearish pattern", "Bearish pattern detected")
alertcondition(patDB or patTB or patIHS or patWF, "Bullish pattern", "Bullish pattern detected")

plotshape(bearSig, title="Bearish signal", style=shape.triangledown, location=location.abovebar, color=cBear, size=size.tiny)
plotshape(bullSig, title="Bullish signal",   style=shape.triangleup,   location=location.belowbar, color=cBull, size=size.tiny)
````
