# Darvas Box Theory [Alpha Extract]

- url: https://www.tradingview.com/script/OEIokWZ0-Darvas-Box-Theory-Alpha-Extract/
- type: indicator
- pine_id: PUB;815da8d37c184a5b9bfac7ee66d60aff
- version: 2.0

## Description

A sophisticated momentum breakout and trend-continuation framework based on Nicolas Darvas’ classic box theory, rebuilt with modern confirmation filters, adaptive risk management, and real-time trade-state tracking. This indicator identifies consolidation ranges, validates breakout conditions through volume and trend confirmation, manages long-side breakout entries, trails stops through higher boxes, and displays a live status dashboard for complete market structure awareness. By combining box compression, volatility filtering, breakout validation, and structured stop logic, the system provides a clean and disciplined framework for trading momentum expansion after consolidation.

🔶 Advanced Darvas Box Detection Engine

Implements a dynamic Darvas box construction model that identifies price consolidation ranges using configurable confirmation bars. The system continuously scans recent market structure, defines the highest high as the box ceiling, the lowest low as the box floor, and validates the range only when the box meets minimum volatility-adjusted height requirements.

[pine]candidateTop = ta.highest(high, boxLen)
candidateBottom = ta.lowest(low, boxLen)
heightOk = (candidateTop - candidateBottom) >= atr * minBoxAtr[/pine]

This ensures boxes are not created from meaningless low-range noise and instead represent tradable compression zones with enough structure to support breakout analysis.

🔶 ATR-Filtered Box Quality Control

Features an adaptive box validation system using Average True Range to measure whether a box has enough height relative to current market volatility. Traders can adjust the Minimum Box Height setting to control how selective the indicator becomes.

A lower ATR threshold creates more boxes and more frequent signals, while a higher threshold filters out weak consolidations and focuses only on larger, cleaner market structures.

🔶 Optional Rising Box Requirement

Includes an optional rising-box filter designed for classic Darvas-style momentum trading. When enabled, the system only accepts new boxes if their ceiling is higher than the previous box top, helping traders focus on progressive bullish structure and avoid lower-quality sideways chop.

This is useful for traders who want to trade continuation setups only when the market is forming higher price ranges.

🔶 Breakout Confirmation Framework

Provides flexible breakout detection using either candle close confirmation or wick-based confirmation. Close mode requires price to close beyond the box boundary for stronger confirmation, while Wick mode reacts as soon as price trades beyond the box level for faster but more aggressive signals.

[pine]upBreakRaw = boxReady and (breakoutMode == "Close" ? close > boxTop : high > boxTop)
longSignal = breakoutUp and volumeOk and trendOk[/pine]

This allows traders to choose between conservative confirmation and faster momentum detection depending on their strategy style.

🔶 Volume Breakout Validation

Integrates volume confirmation to help filter weak breakouts and highlight expansion moves supported by stronger market participation. The system compares current volume against a moving average baseline and requires breakout volume to exceed a configurable multiplier.

This helps identify breakouts with real participation rather than low-volume fakeouts.

🔶 Trend Filter Integration

Uses a configurable EMA trend filter to align breakout signals with the broader market direction. When enabled, long breakout signals are only accepted when price is trading above the selected trend EMA.

This keeps the system focused on momentum continuation setups rather than counter-trend breakouts with weaker follow-through potential.

🔶 Automated Darvas Trade State Engine

Transforms box breakouts into a structured trade-management framework. When price breaks above a completed box with valid trend and volume confirmation, the system enters a long trade state, stores the entry price, initializes the stop level, and begins live trade tracking.

The indicator then monitors whether price continues into higher boxes, generates add signals, or exits when the stop or downside breakdown condition is triggered.

🔶 Add Signal & Higher Box Continuation Logic

Features higher-box continuation logic that identifies additional momentum opportunities while already in a long position. If a new confirmed breakout occurs above the original entry price while the trade is active, the system generates an Add signal and updates the trade structure.

This helps traders scale into trending moves as the market builds new Darvas boxes above the previous structure.

🔶 Adaptive Stop Management System

Provides three different stop modes for flexible risk management:

• Box Floor — places the stop at the bottom of the Darvas box.
• Breached Ceiling — uses the breakout ceiling as the protective reference.
• ATR — applies a volatility-adjusted trailing stop based on ATR.


[pine]baseStop = stopMode == "Breached Ceiling" ? boxTop : stopMode == "ATR" ? src - atr * atrStopMult : boxBottom
exitSignal := tradeState == 1 and (src < trailStop or breakoutDown)[/pine]


This allows traders to choose between structural, breakout-level, or volatility-based protection depending on their trading approach.

🔶 Trail Stop To Higher Boxes

Includes automatic stop advancement as price confirms higher boxes. When enabled, the stop trails upward with stronger box structures, helping lock in gains while allowing the trend to continue.

This creates a disciplined trend-following system that protects profits without exiting too early during strong momentum phases.

🔶 Breakdown & Exit Logic

Implements clean exit handling when price falls below the active trailing stop or breaks down through the box floor. This gives the system a defined invalidation structure and prevents trades from remaining active after momentum has failed.

Exit markers are displayed directly on the chart for fast visual confirmation.

🔶 Real-Time Status Dashboard

Features a compact live dashboard displaying the most important Darvas trade and box information in real time. The table shows:

• Current trade state
• Box top
• Box floor
• Volume ratio
• Trend filter status
• Distance to breakout
• Box height relative to ATR
• Open R multiple

This gives traders an immediate overview of whether the market is forming a box, preparing for breakout, actively in a trade, or filtered by trend/volume conditions.

🔶 Clean Visual Box Architecture

Creates a clear visual representation of forming and completed Darvas boxes using configurable colors, transparency, top and bottom level lines, breakout markers, exit markers, and optional grey candle overlay. Forming boxes are displayed separately from completed bullish or bearish boxes, making it easy to distinguish live consolidation from confirmed breakout structure.

The system also manages historical box limits automatically to keep charts clean and prevent visual overload.

🔶 Performance Optimization & Historical Box Management

Uses efficient array-based storage and automatic cleanup logic to manage historical boxes, lines, and chart objects. Traders can control how many completed boxes remain visible, allowing the indicator to preserve historical context while maintaining smooth TradingView performance.

This makes the tool suitable for both short-term and long-term chart analysis.

🔶 Comprehensive Alert System

Includes alert conditions for the most important Darvas events:

• Darvas Box Buy
• Darvas Box Add
• Darvas Box Exit

These alerts allow traders to monitor breakout opportunities, continuation setups, and invalidation events without watching the chart constantly.

🔶 Why Choose Darvas Box Theory [Alpha Extract]?

This indicator modernizes the classic Darvas Box strategy by combining traditional breakout structure with advanced confirmation logic, volatility filtering, dynamic stop management, and real-time trade monitoring. Instead of simply drawing static boxes, the system evaluates whether each range has enough volatility, confirms whether breakouts are backed by volume, checks whether price is aligned with the broader trend, and then manages the trade through structured stop logic.

The result is a clean momentum trading framework designed to help traders identify compression, wait for confirmed expansion, manage entries with discipline, scale into higher-box continuation, and exit when the structure fails. Perfect for trend-following traders, breakout traders, swing traders, and systematic momentum traders looking for a more complete version of the classic Darvas Box methodology.

## Source Code

````pine
//@version=6
indicator("Darvas Box Theory [Alpha Extract]", shorttitle = "Darvas Box", overlay = true, max_boxes_count = 200, max_lines_count = 200, max_labels_count = 200, behind_chart = false)

// INPUTS
src = input.source(close, "Source", group = "Darvas Engine")
boxLen = input.int(5, "Box Confirmation Bars", minval = 2, maxval = 50, group = "Darvas Engine", tooltip = "Higher values create slower but more reliable boxes.")
minBoxAtr = input.float(0.35, "Minimum Box Height (ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = "Darvas Engine")
requireRisingBox = input.bool(false, "Require Rising Boxes", group = "Darvas Engine")
breakoutMode = input.string("Close", "Breakout Method", options = ["Close", "Wick"], group = "Darvas Engine")
maxStoredBoxes = input.int(80, "Historical Boxes", minval = 5, maxval = 190, group = "Darvas Engine")

useVolume = input.bool(true, "Use Volume Confirmation", group = "Volume")
volLength = input.int(20, "Volume Average Length", minval = 1, maxval = 200, group = "Volume")
volMultiplier = input.float(1.5, "Breakout Volume Multiplier", minval = 0.1, maxval = 10.0, step = 0.1, group = "Volume")

useTrend = input.bool(true, "Use Trend Filter", group = "Trend")
trendLength = input.int(200, "Trend EMA Length", minval = 10, maxval = 500, group = "Trend")

stopMode = input.string("Box Floor", "Stop Mode", options = ["Box Floor", "Breached Ceiling", "ATR"], group = "Risk")
atrLength = input.int(14, "ATR Length", minval = 1, maxval = 100, group = "Risk")
atrStopMult = input.float(2.0, "ATR Stop Multiplier", minval = 0.1, maxval = 10.0, step = 0.1, group = "Risk")
trailToHigherBoxes = input.bool(true, "Trail Stop To Higher Boxes", group = "Risk")

showBoxes = input.bool(true, "Show Boxes", group = "Display")
showBoxLines = input.bool(true, "Show Top / Bottom Lines", group = "Display")
showSignals = input.bool(true, "Show Signals", group = "Display")
showStop = input.bool(true, "Show Stop", group = "Display")
showTable = input.bool(true, "Show Status Table", group = "Display")
candleColor = input.color(color.rgb(135, 142, 155), "Candle Color", group = "Display")
bullColor = input.color(color.rgb(47, 255, 54), "Bull Color", group = "Display")
bearColor = input.color(color.rgb(255, 0, 20), "Risk Color", group = "Display")
formingBoxColor = input.color(color.rgb(255, 255, 255), "Forming Box Color", group = "Display")
bullBoxColor = input.color(color.rgb(84, 210, 88), "Bull Box Color", group = "Display")
bearBoxColor = input.color(color.rgb(255, 0, 20), "Bear Box Color", group = "Display")
boxFillTransparency = input.int(90, "Box Fill Transparency", minval = 0, maxval = 100, group = "Display")
boxLineTransparency = input.int(52, "Box Line Transparency", minval = 0, maxval = 100, group = "Display")

// FUNCTIONS
f_posColor(bool ok) =>
    ok ? color.new(bullColor, 0) : color.new(bearColor, 0)

f_cell(table t, int c, int r, string txt, color txtCol, color bgCol) =>
    table.cell(t, c, r, txt, text_color = txtCol, bgcolor = bgCol, text_size = size.small)

f_trimBoxes(array<box> boxes, int maxCount) =>
    if array.size(boxes) > maxCount
        oldBox = array.shift(boxes)
        box.delete(oldBox)

f_trimLinePairs(array<line> lines, int maxPairs) =>
    if array.size(lines) > maxPairs * 2
        oldLine1 = array.shift(lines)
        line.delete(oldLine1)
        oldLine2 = array.shift(lines)
        line.delete(oldLine2)

f_newBox(int left, float top, int right, float bottom, color boxColor) =>
    box.new(left, top, right, bottom, border_color = color.new(boxColor, boxLineTransparency), bgcolor = color.new(boxColor, boxFillTransparency))

f_newLevelLine(int left, float price, int right, color lineColor) =>
    line.new(left, price, right, price, color = color.new(lineColor, boxLineTransparency), width = 2)

f_extendBox(box targetBox, int right) =>
    if not na(targetBox)
        box.set_right(targetBox, right)

f_extendLine(line targetLine, int right) =>
    if not na(targetLine)
        line.set_x2(targetLine, right)

f_styleBox(box targetBox, color boxColor) =>
    if not na(targetBox)
        box.set_border_color(targetBox, color.new(boxColor, boxLineTransparency))
        box.set_bgcolor(targetBox, color.new(boxColor, boxFillTransparency))

f_styleLine(line targetLine, color lineColor) =>
    if not na(targetLine)
        line.set_color(targetLine, color.new(lineColor, boxLineTransparency))

f_extendDrawings(box targetBox, line upperLine, line lowerLine, int right) =>
    f_extendBox(targetBox, right)
    f_extendLine(upperLine, right)
    f_extendLine(lowerLine, right)

f_completeDrawings(box targetBox, line upperLine, line lowerLine, int right, color completedColor) =>
    f_extendDrawings(targetBox, upperLine, lowerLine, right)
    f_styleBox(targetBox, completedColor)
    f_styleLine(upperLine, completedColor)
    f_styleLine(lowerLine, completedColor)

// CORE CALCULATIONS
atr = ta.atr(atrLength)
trendEma = ta.ema(src, trendLength)
volAvg = ta.sma(volume, volLength)
volumeOk = not useVolume or volume >= volAvg * volMultiplier
trendOk = not useTrend or src > trendEma

candidateTop = ta.highest(high, boxLen)
candidateBottom = ta.lowest(low, boxLen)
candidateHeight = candidateTop - candidateBottom
heightOk = candidateHeight >= atr * minBoxAtr

// BOX STATE
var float boxTop = na
var float boxBottom = na
var float previousBoxTop = na
var int boxLeft = na
var int boxState = 0
var box activeBox = na
var line topLine = na
var line bottomLine = na
var array<box> storedBoxes = array.new_box()
var array<line> storedLines = array.new_line()

boxCanRise = not requireRisingBox or na(previousBoxTop) or candidateTop > previousBoxTop
boxCanStart = boxState == 0 and bar_index >= boxLen - 1 and heightOk and boxCanRise

if boxCanStart
    boxTop := candidateTop
    boxBottom := candidateBottom
    boxLeft := bar_index - boxLen + 1
    boxState := 1

    if showBoxes
        activeBox := f_newBox(boxLeft, boxTop, bar_index, boxBottom, formingBoxColor)
        array.push(storedBoxes, activeBox)
        f_trimBoxes(storedBoxes, maxStoredBoxes)

    if showBoxLines
        topLine := f_newLevelLine(boxLeft, boxTop, bar_index, formingBoxColor)
        bottomLine := f_newLevelLine(boxLeft, boxBottom, bar_index, formingBoxColor)
        array.push(storedLines, topLine)
        array.push(storedLines, bottomLine)
        f_trimLinePairs(storedLines, maxStoredBoxes)

boxReady = boxState == 1 and not na(boxTop) and not na(boxBottom)

if boxReady
    if showBoxes
        f_extendBox(activeBox, bar_index)
    if showBoxLines
        f_extendLine(topLine, bar_index)
        f_extendLine(bottomLine, bar_index)

// BREAKOUT AND TRADE STATE
upBreakRaw = boxReady and (breakoutMode == "Close" ? close > boxTop : high > boxTop)
downBreakRaw = boxReady and (breakoutMode == "Close" ? close < boxBottom : low < boxBottom)
baseStop = stopMode == "Breached Ceiling" ? boxTop : stopMode == "ATR" ? src - atr * atrStopMult : boxBottom

var int tradeState = 0
var float entryPrice = na
var float trailStop = na
var int adds = 0

breakoutUp = false
breakoutDown = false
longSignal = false
addSignal = false
exitSignal = false

if upBreakRaw or downBreakRaw
    breakoutUp := upBreakRaw
    breakoutDown := downBreakRaw and not upBreakRaw
    longSignal := breakoutUp and volumeOk and trendOk
    completedBoxColor = breakoutUp ? bullBoxColor : bearBoxColor

    f_completeDrawings(activeBox, topLine, bottomLine, bar_index, completedBoxColor)

    if longSignal and tradeState == 0
        tradeState := 1
        entryPrice := src
        trailStop := baseStop
        adds := 0
    else if longSignal and tradeState == 1 and src > entryPrice
        addSignal := true
        adds += 1
        if trailToHigherBoxes
            trailStop := math.max(nz(trailStop, baseStop), baseStop)

    if tradeState == 1 and trailToHigherBoxes and boxTop > nz(previousBoxTop, boxTop)
        trailStop := math.max(nz(trailStop, baseStop), baseStop)

    previousBoxTop := boxTop
    boxState := 0
    activeBox := na
    topLine := na
    bottomLine := na

exitSignal := tradeState == 1 and (src < trailStop or breakoutDown)
if exitSignal
    tradeState := 0
    entryPrice := na
    trailStop := na
    adds := 0

// STATUS VALUES
distanceToBreakout = boxReady ? (boxTop - src) / src * 100.0 : na
boxHeightAtr = boxReady and atr > 0 ? (boxTop - boxBottom) / atr : na
volRatio = volAvg > 0 ? volume / volAvg : na
openR = tradeState == 1 and not na(entryPrice) and not na(trailStop) and entryPrice != trailStop ? (src - entryPrice) / math.abs(entryPrice - trailStop) : na

// PLOTS
plot(useTrend ? trendEma : na, "Trend EMA", color = color.new(color.white, 55), linewidth = 1)
plot(showStop and tradeState == 1 ? trailStop : na, "Darvas Stop", color = bearColor, linewidth = 2, style = plot.style_linebr)

plotshape(showSignals and longSignal and tradeState[1] == 0, "Darvas Buy", shape.triangleup, location.belowbar, color = bullColor, size = size.small, text = "BUY", textcolor = color.white)
plotshape(showSignals and addSignal, "Darvas Add", shape.circle, location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showSignals and exitSignal, "Darvas Exit", shape.triangledown, location.abovebar, color = bearColor, size = size.small, text = "EXIT", textcolor = color.white)
plotshape(showSignals and breakoutDown and tradeState[1] == 0, "Darvas Breakdown", shape.triangledown, location.abovebar, color = bearColor, size = size.tiny, text = "BRK", textcolor = color.white)

plotcandle(open, high, low, close, title = "Grey Candles", color = candleColor, wickcolor = candleColor, bordercolor = candleColor, force_overlay = true)

// STATUS TABLE
var table status = table.new(position.top_right, 2, 8, frame_color = color.new(color.white, 70), frame_width = 1, border_width = 0)

if barstate.islast
    table.clear(status, 0, 0, 1, 7)
    if showTable
        bg = color.new(color.black, 0)
        headerBg = color.new(color.rgb(24, 27, 34), 0)
        txt = color.white
        muted = color.new(color.white, 45)

        f_cell(status, 0, 0, "Darvas Box", txt, headerBg)
        f_cell(status, 1, 0, tradeState == 1 ? "Long" : "Watching", tradeState == 1 ? bullColor : muted, headerBg)

        f_cell(status, 0, 1, "Box Top", muted, bg)
        f_cell(status, 1, 1, boxReady ? str.tostring(boxTop, format.mintick) : "-", txt, bg)

        f_cell(status, 0, 2, "Box Floor", muted, bg)
        f_cell(status, 1, 2, boxReady ? str.tostring(boxBottom, format.mintick) : "-", txt, bg)

        f_cell(status, 0, 3, "Vol", muted, bg)
        f_cell(status, 1, 3, na(volRatio) ? "-" : str.tostring(volRatio, "#.##") + "x", f_posColor(volumeOk), bg)

        f_cell(status, 0, 4, "Trend", muted, bg)
        f_cell(status, 1, 4, trendOk ? "Passed" : "Filtered", f_posColor(trendOk), bg)

        f_cell(status, 0, 5, "Distance", muted, bg)
        f_cell(status, 1, 5, na(distanceToBreakout) ? "-" : str.tostring(distanceToBreakout, "#.##") + "%", txt, bg)

        f_cell(status, 0, 6, "Box / ATR", muted, bg)
        f_cell(status, 1, 6, na(boxHeightAtr) ? "-" : str.tostring(boxHeightAtr, "#.##"), txt, bg)

        f_cell(status, 0, 7, "Open R", muted, bg)
        f_cell(status, 1, 7, na(openR) ? "-" : str.tostring(openR, "#.##") + "R", na(openR) or openR >= 0 ? bullColor : bearColor, bg)

// ALERTS
alertcondition(longSignal and tradeState[1] == 0, "Darvas Box Buy", "Darvas Box Momentum Engine: breakout with confirmation.")
alertcondition(addSignal, "Darvas Box Add", "Darvas Box Momentum Engine: higher box/add signal.")
alertcondition(exitSignal, "Darvas Box Exit", "Darvas Box Momentum Engine: stop or box floor exit.")
````
