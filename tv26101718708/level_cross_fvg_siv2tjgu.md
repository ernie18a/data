# Level Cross FVG

- url: https://www.tradingview.com/script/siV2tjGU-Level-Cross-FVG/
- type: indicator
- pine_id: PUB;c44291da651f4667ad61eeb9115c4219
- version: 1.0

## Description

Level Cross FVG is a clean charting tool designed to highlight selected Fair Value Gap zones with customizable visibility, styling, and box management.

It helps traders keep their charts organized by displaying only relevant zones based on the indicator’s configured filters and settings.

Features:
- Customizable valid and violated zone colors
- Optional violated-zone extension
- Adjustable maximum number of displayed boxes
- Intraday, lookback-session, or all-history box retention modes
- Wick or close based violation setting
- Configurable level filter groups
- Optional Opening Range session setting
- Lightweight overlay design for clean chart reading

This indicator is intended as a visual support tool for chart analysis and should be used alongside your own trading plan and risk management.

## Source Code

````pine
//@version=6
indicator("Level Cross FVG", overlay=true, max_boxes_count=500)

// -- FVG Settings --------------------------------------------------------------
gFVG = "1. FVG Settings"
showFVG = input.bool(true, "Detect FVG on Level Cross", group=gFVG)
validCol = input.color(color.new(color.green, 70), "Valid FVG Color", group=gFVG)
violatedCol = input.color(color.new(color.red, 70), "Violated FVG Color", group=gFVG)
borderCol = input.color(color.new(color.white, 60), "Border Color", group=gFVG)
extendViolated = input.bool(false, "Extend Violated Boxes", group=gFVG)
maxFVGs = input.int(50, "Maximum FVG Boxes", minval=1, maxval=500, group=gFVG)
keepMode = input.string("Intraday Only", "Keep FVG Boxes", options=["Intraday Only", "Lookback Sessions", "All"], group=gFVG)
lookbackSessions = input.int(3, "Lookback Sessions", minval=1, maxval=60, group=gFVG)
invalidationMode = input.string("Wick", "Violation Method", options=["Wick", "Close"], group=gFVG)
levelBreakMode = input.string("Close", "Level Break Method", options=["Close", "Wick"], group=gFVG)

// -- Level Filters -------------------------------------------------------------
gLevels = "2. Level Cross Filters"
usePD = input.bool(true, "Use PDH / PDL / PDC", group=gLevels)
useCPR = input.bool(true, "Use CPR", group=gLevels)
usePivots = input.bool(true, "Use Pivot R/S Levels", group=gLevels)
useOR = input.bool(true, "Use ORH / ORL", group=gLevels)
orSession = input.session("0915-0930", "Opening Range Time", group=gLevels)
useR3S3 = input.bool(true, "Use R3 / S3", group=gLevels)
useR4S4 = input.bool(false, "Use R4 / S4", group=gLevels)
useR5S5 = input.bool(false, "Use R5 / S5", group=gLevels)

// -- Daily OHLC from previous day ---------------------------------------------
[dH, dL, dC] = request.security(
     syminfo.tickerid,
     "D",
     [high[1], low[1], close[1]],
     lookahead=barmerge.lookahead_on)

rng = dH - dL

// -- Traditional pivots and CPR. These are trigger levels only; they are not plotted.
pp = (dH + dL + dC) / 3
r1 = 2 * pp - dL
r2 = pp + rng
r3 = dH + 2 * (pp - dL)
r4 = r3 + rng
r5 = r4 + rng
s1 = 2 * pp - dH
s2 = pp - rng
s3 = dL - 2 * (dH - pp)
s4 = s3 - rng
s5 = s4 - rng

cprBC = (dH + dL) / 2
cprTC = 2 * pp - cprBC

isNewDay = ta.change(time("D")) != 0

// -- Opening Range. These are trigger levels only; they are not plotted.
inOR = not na(time(timeframe.period, orSession))
orStart = inOR and not inOR[1]
orEnd = not inOR and inOR[1]

var float orHigh = na
var float orLow = na
var bool orReady = false

if isNewDay
    orHigh := na
    orLow := na
    orReady := false

if orStart
    orHigh := high
    orLow := low
    orReady := false

if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)

if orEnd
    orReady := true

// -- FVG detection -------------------------------------------------------------
// Bullish FVG: candle two bars back high is below current candle low.
// Bearish FVG: candle two bars back low is above current candle high.
isBullFVG = high[2] < low
isBearFVG = low[2] > high

fvgTop = isBullFVG ? low : isBearFVG ? low[2] : na
fvgBot = isBullFVG ? high[2] : isBearFVG ? high : na

// FVG definition: candle [1] is the level-breaking candle.
// The FVG is confirmed only after the next candle exists, using the gap
// between candle [2] and the current candle around that breaker candle.
levelBrokenByMiddleCandle(level) =>
    closeBreak = (isBullFVG and close[2] <= level and close[1] > level) or (isBearFVG and close[2] >= level and close[1] < level)
    wickBreak = (isBullFVG and high[1] >= level and close[1] > level) or (isBearFVG and low[1] <= level and close[1] < level)
    not na(level) and (levelBreakMode == "Close" ? closeBreak : wickBreak)

crossedLevel(level) =>
    levelBrokenByMiddleCandle(level)

crossPD = usePD and (crossedLevel(dH) or crossedLevel(dL) or crossedLevel(dC))
crossCPR = useCPR and (crossedLevel(cprTC) or crossedLevel(pp) or crossedLevel(cprBC))
crossPivots = usePivots and (
     crossedLevel(pp) or
     crossedLevel(r1) or crossedLevel(r2) or
     (useR3S3 and (crossedLevel(r3) or crossedLevel(s3))) or
     (useR4S4 and (crossedLevel(r4) or crossedLevel(s4))) or
     (useR5S5 and (crossedLevel(r5) or crossedLevel(s5))) or
     crossedLevel(s1) or crossedLevel(s2))
crossOR = useOR and orReady and (crossedLevel(orHigh) or crossedLevel(orLow))

levelCrossed = crossPD or crossCPR or crossPivots or crossOR
newQualifiedFVG = showFVG and levelCrossed and (isBullFVG or isBearFVG) and not na(fvgTop) and not na(fvgBot)

// -- FVG state -----------------------------------------------------------------
var box[] fvgBoxes = array.new<box>()
var float[] fvgTops = array.new<float>()
var float[] fvgBots = array.new<float>()
var bool[] fvgBulls = array.new<bool>()
var bool[] fvgViolated = array.new<bool>()
var int[] fvgBorn = array.new<int>()
var int[] fvgBornSession = array.new<int>()

var int sessionCounter = 0
if isNewDay
    sessionCounter += 1

clearAllBoxes() =>
    boxCount = array.size(fvgBoxes)
    if boxCount > 0
        for i = 0 to boxCount - 1
            box.delete(array.get(fvgBoxes, i))
    array.clear(fvgBoxes)
    array.clear(fvgTops)
    array.clear(fvgBots)
    array.clear(fvgBulls)
    array.clear(fvgViolated)
    array.clear(fvgBorn)
    array.clear(fvgBornSession)

trimOldBoxes() =>
    while array.size(fvgBoxes) > maxFVGs
        oldBox = array.shift(fvgBoxes)
        box.delete(oldBox)
        array.shift(fvgTops)
        array.shift(fvgBots)
        array.shift(fvgBulls)
        array.shift(fvgViolated)
        array.shift(fvgBorn)
        array.shift(fvgBornSession)

deleteBoxAt(index) =>
    oldBox = array.remove(fvgBoxes, index)
    box.delete(oldBox)
    array.remove(fvgTops, index)
    array.remove(fvgBots, index)
    array.remove(fvgBulls, index)
    array.remove(fvgViolated, index)
    array.remove(fvgBorn, index)
    array.remove(fvgBornSession, index)

pruneByKeepMode() =>
    if keepMode == "Lookback Sessions"
        cutoffSession = sessionCounter - lookbackSessions + 1
        idx = array.size(fvgBoxes) - 1
        while idx >= 0
            if array.get(fvgBornSession, idx) < cutoffSession
                deleteBoxAt(idx)
            idx -= 1

if keepMode == "Intraday Only" and isNewDay
    clearAllBoxes()

pruneByKeepMode()

if newQualifiedFVG
    newBox = box.new(
         left=bar_index - 2,
         top=fvgTop,
         right=bar_index,
         bottom=fvgBot,
         border_color=borderCol,
         bgcolor=validCol,
         border_width=1)
    array.push(fvgBoxes, newBox)
    array.push(fvgTops, fvgTop)
    array.push(fvgBots, fvgBot)
    array.push(fvgBulls, isBullFVG)
    array.push(fvgViolated, false)
    array.push(fvgBorn, bar_index)
    array.push(fvgBornSession, sessionCounter)
    trimOldBoxes()
    pruneByKeepMode()

// -- Update boxes. Valid boxes stay green; violated boxes turn red.
boxCount = array.size(fvgBoxes)
if boxCount > 0
    for i = 0 to boxCount - 1
        bx = array.get(fvgBoxes, i)
        top = array.get(fvgTops, i)
        bot = array.get(fvgBots, i)
        isBull = array.get(fvgBulls, i)
        violated = array.get(fvgViolated, i)
        born = array.get(fvgBorn, i)

        if not violated or extendViolated
            box.set_right(bx, bar_index)

        if not violated and bar_index > born
            bullViolated = invalidationMode == "Close" ? close <= bot : low <= bot
            bearViolated = invalidationMode == "Close" ? close >= top : high >= top
            nowViolated = isBull ? bullViolated : bearViolated

            if nowViolated
                array.set(fvgViolated, i, true)
                box.set_right(bx, bar_index)
                box.set_bgcolor(bx, violatedCol)
                box.set_border_color(bx, violatedCol)
````
